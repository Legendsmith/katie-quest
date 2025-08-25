extends Panel

@onready var mic_selector: OptionButton = $Microphone/MicSelector/OptionButton
@onready var test_button: Button = $Microphone/Button
@onready var mic_level: ProgressBar = $Microphone/MicLevel/ProgressBar
@onready var mic_gain: HSlider = $Microphone/MicLevel/HSlider
@onready var next_button: Button = $Microphone/Next

var audio_stream_mic: AudioStreamMicrophone
var audio_player: AudioStreamPlayer
var capture_effect: AudioEffectCapture
var is_testing = false
var mic_gain_value = 1.0

func _ready():
	populate_microphones()
	setup_audio()

	test_button.pressed.connect(_on_test_pressed)
	next_button.pressed.connect(_on_next_pressed)
	mic_gain.connect("value_changed", _on_gain_changed)

	mic_level.min_value = 0
	mic_level.max_value = 100
	mic_level.value = 0

func populate_microphones():
	mic_selector.clear()
	var devices = AudioServer.get_input_device_list()
	for device in devices:
		mic_selector.add_item(device)

func setup_audio():
	audio_stream_mic = AudioStreamMicrophone.new()
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Microphone"
	add_child(audio_player)

	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	capture_effect = AudioEffectCapture.new()
	AudioServer.add_bus_effect(mic_bus_index, capture_effect)

func _on_test_pressed():
	is_testing = !is_testing

	if is_testing:
		if mic_selector.selected >= 0:
			var selected_device = mic_selector.get_item_text(mic_selector.selected)
			AudioServer.set_input_device(selected_device)

		var mic_bus_index = AudioServer.get_bus_index("Microphone")
		AudioServer.set_bus_mute(mic_bus_index, true)

		capture_effect.clear_buffer()
		audio_player.stream = audio_stream_mic
		audio_player.play()
		test_button.text = "Stop Test"

	else:
		var mic_bus_index = AudioServer.get_bus_index("Microphone")
		AudioServer.set_bus_mute(mic_bus_index, false)
		audio_player.stop()
		test_button.text = "Test Mic"

func _process(_delta):
	if is_testing and audio_player.playing:
		var frames = capture_effect.get_frames_available()
		if frames > 0:
			var buffer = capture_effect.get_buffer(frames)
			var level = 0.0

			for frame in buffer:
				level += frame.x * frame.x

			level = sqrt(level / frames) * 100
			level *= mic_gain_value
			mic_level.value = clamp(level, 0, 100)

func _on_gain_changed(value: float):
	mic_gain_value = value / 100.0

func _on_next_pressed():
	if mic_selector.selected >= 0:
		var selected_device = mic_selector.get_item_text(mic_selector.selected)
		GameSettings.set_microphone_settings(selected_device, mic_gain_value)

	# Load next calibration scene
	# Fade.change_scene("res://path/to/next_calibration.tscn")