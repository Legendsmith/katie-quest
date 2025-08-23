extends Control

@onready var ui_settings_container = $TabContainer/Sound/MarginContainer/VBoxContainer
@onready var ui_sound_container = ui_settings_container.get_node("Sliders")
@onready var ui_mic_container = ui_settings_container.get_node("Microphone")
@onready var ui_back_to_menu = ui_settings_container.get_node("BackToMenu")

@onready var ui_sound_master: Slider = ui_sound_container.get_node("SliderMaster")
@onready var ui_sound_music: Slider = ui_sound_container.get_node("SliderMusic")
@onready var ui_sound_effects: Slider = ui_sound_container.get_node("SliderEffects")
@onready var ui_sound_voices: Slider = ui_sound_container.get_node("SliderVoices")

@onready var ui_mic_selector: OptionButton = ui_mic_container.get_node("MicSelector/OptionButton")
@onready var ui_mic_test: Button = ui_mic_container.get_node("Button")
@onready var ui_mic_level: ProgressBar = ui_mic_container.get_node("MicLevel/ProgressBar")
@onready var ui_mic_gain: HSlider = ui_mic_container.get_node("MicLevel/HSlider")

var audio_stream_mic: AudioStreamMicrophone
var audio_player: AudioStreamPlayer
var capture_effect: AudioEffectCapture

var is_testing = false

var mic_gain = 1.0

func _ready():
	ui_sound_master.connect("value_changed", func(value: float): _handle_audio_volume("Sound Master", value))
	ui_sound_music.connect("value_changed", func(value: float): _handle_audio_volume("Music", value))
	ui_sound_effects.connect("value_changed", func(value: float): _handle_audio_volume("Effects", value))
	ui_sound_voices.connect("value_changed", func(value: float): _handle_audio_volume("Voices", value))

	ui_mic_gain.connect("value_changed", _on_mic_gain_changed)

	ui_back_to_menu.pressed.connect(_on_back_to_menu_pressed)

	audio_stream_mic = AudioStreamMicrophone.new()
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Microphone"
	add_child(audio_player)

	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	capture_effect = AudioEffectCapture.new()
	AudioServer.add_bus_effect(mic_bus_index, capture_effect)
	
	ui_mic_level.min_value = 0
	ui_mic_level.max_value = 100
	ui_mic_level.value = 0

	populate_microphones()

	ui_mic_test.pressed.connect(_on_mic_test_pressed)
	ui_mic_test.text = "Test Microphone"

func _handle_audio_volume(bus_name: String, volume: float):
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_error("Bus {str} not found!".format({ "str": bus_name }))
		return

	var db: float = lerp(-80, 0, clamp(volume / 100, 0, 1))

	AudioServer.set_bus_volume_db(bus_index, db)

func populate_microphones():
	if ui_mic_selector == null:
		push_error("ui_mic_selector is null - check node path")
		return

	ui_mic_selector.clear()

	var devices = AudioServer.get_input_device_list()
	for device in devices:
		ui_mic_selector.add_item(device)

func _on_mic_test_pressed():
	is_testing = !is_testing

	if is_testing:
		if ui_mic_selector.selected >= 0:
			var selected_device = ui_mic_selector.get_item_text(ui_mic_selector.selected)
			AudioServer.set_input_device(selected_device)

		var mic_bus_index = AudioServer.get_bus_index("Microphone")
		AudioServer.set_bus_mute(mic_bus_index, true)
		
		capture_effect.clear_buffer()
		audio_player.stream = audio_stream_mic
		audio_player.play()
		ui_mic_test.text = "Stop Test"
	else:
		var mic_bus_index = AudioServer.get_bus_index("Microphone")
		AudioServer.set_bus_mute(mic_bus_index, false)
		audio_player.stop()
		ui_mic_test.text = "Test Microphone"

func _process(delta):
	if is_testing and audio_player.playing:
		var frames = capture_effect.get_frames_available()

		if frames > 0:
			var buffer = capture_effect.get_buffer(frames)
			var level = 0.0

			for frame in buffer:
				level += frame.x * frame.x

			level = sqrt(level / frames) * 100
			level *= mic_gain
			ui_mic_level.value = clamp(level, 0, 100)

func _on_mic_gain_changed(value: float):
	mic_gain = value / 100.0

func _on_back_to_menu_pressed():
	if is_testing:
		is_testing = false
		audio_player.stop()
		var mic_bus_index = AudioServer.get_bus_index("Microphone")
		AudioServer.set_bus_mute(mic_bus_index, false)

	Fade.change_scene("res://ui/main_menu.tscn")
