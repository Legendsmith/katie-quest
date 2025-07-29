extends Control

@onready var ui_sound_container = $TabContainer/Sound/MarginContainer/GridContainer
@onready var ui_sound_master: Slider = ui_sound_container.get_node("SliderMaster")
@onready var ui_sound_music: Slider = ui_sound_container.get_node("SliderMusic")
@onready var ui_sound_effects: Slider = ui_sound_container.get_node("SliderEffects")
@onready var ui_sound_voices: Slider = ui_sound_container.get_node("SliderVoices")

func _handle_audio_volume(bus_name: String, volume: float):
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_error("Bus {str} not found!".format({ "str": bus_name }))
		return

	var db: float = lerp(-80, 0, clamp(volume / 100, 0, 1))

	AudioServer.set_bus_volume_db(bus_index, db)

func _ready():
	ui_sound_master.connect("value_changed", func(value: float): _handle_audio_volume("Master", value))
	ui_sound_music.connect("value_changed", func(value: float): _handle_audio_volume("Music", value))
	ui_sound_effects.connect("value_changed", func(value: float): _handle_audio_volume("Effects", value))
	ui_sound_voices.connect("value_changed", func(value: float): _handle_audio_volume("Voices", value))
