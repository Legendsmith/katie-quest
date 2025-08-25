extends Panel

@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var button: Button = $MarginContainer/VBoxContainer/Button
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var next_button: Button = $MarginContainer/VBoxContainer/Next

var audio_stream_mic: AudioStreamMicrophone
var audio_player: AudioStreamPlayer
var capture_effect: AudioEffectCapture

var is_calibrating = false
var calibration_phase = 0
var calibration_duration = 10.0
var calibration_timer = 0.0

var volume_readings = []
var talking_threshold = 0.0
var scream_threshold = 0.0

func _ready():
	button.pressed.connect(_on_start_calibration)
	next_button.pressed.connect(_on_next_phase)

	progress_bar.visible = false
	next_button.visible = false
	progress_bar.min_value = 0
	progress_bar.max_value = 100

	setup_audio()

func setup_audio():
	var selected_device = GameSettings.get_microphone_device()
	if selected_device != "":
		AudioServer.set_input_device(selected_device)

	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	capture_effect = AudioEffectCapture.new()
	AudioServer.add_bus_effect(mic_bus_index, capture_effect)

	audio_stream_mic = AudioStreamMicrophone.new()
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Microphone"
	add_child(audio_player)

func _on_start_calibration():
	start_phase_1()

func _on_next_phase():
	start_phase_2()

func start_phase_1():
	calibration_phase = 1
	is_calibrating = true
	calibration_timer = 0.0
	volume_readings.clear()

	progress_bar.visible = true
	progress_bar.value = 0
	label.text = "Please talk into the mic"
	button.disabled = true

	start_microphone()

func start_phase_2():
	calibration_phase = 2
	is_calibrating = true
	calibration_timer = 0.0
	volume_readings.clear()

	progress_bar.value = 0
	label.text = "Now scream into the mic"
	next_button.disabled = true

	start_microphone()

func start_microphone():
	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	AudioServer.set_bus_mute(mic_bus_index, true)
	capture_effect.clear_buffer()
	audio_player.stream = audio_stream_mic
	audio_player.play()

func _process(delta):
	if not is_calibrating:
		return
	
	calibration_timer += delta
	var progress = min(calibration_timer / calibration_duration * 100, 100)
	progress_bar.value = progress

	if audio_player.playing:
		var frames = capture_effect.get_frames_available()
		if frames > 0:
			var buffer = capture_effect.get_buffer(frames)
			var level = 0.0

			for frame in buffer:
				level += frame.x * frame.x

			level = sqrt(level / frames)
			level *= GameSettings.get_microphone_gain()
			volume_readings.append(level)

	if calibration_timer >= calibration_duration:
		complete_current_phase()

func complete_current_phase():
	is_calibrating = false
	stop_microphone()

	if calibration_phase == 1:
		complete_phase_1()

	elif calibration_phase == 2:
		complete_phase_2()

func complete_phase_1():
	volume_readings.sort()
	var total_readings = volume_readings.size()
	var start_index = int(total_readings * 0.1)
	var end_index = int(total_readings * 0.9)

	var sum = 0.0
	var count = 0

	for i in range(start_index, end_index):
		sum += volume_readings[i]
		count += 1

	talking_threshold = sum / count if count > 0 else 0.0
	print("Talking threshold: ", talking_threshold)

	next_button.visible = true
	button.disabled = false
	label.text = "First calibration complete!"

func complete_phase_2():
	volume_readings.sort()
	var total_readings = volume_readings.size()
	var start_index = int(total_readings * 0.8)

	var sum = 0.0
	var count = 0

	for i in range(start_index, total_readings):
		sum += volume_readings[i]
		count += 1

	var top_20_average = sum / count if count > 0 else 0.0
	scream_threshold = top_20_average * 0.8
	print("Scream threshold: ", scream_threshold)

	GameSettings.set_voice_thresholds(talking_threshold, scream_threshold)

	label.text = "Calibration complete!"
	button.disabled = false

	next_button.visible = true
	next_button.disabled = false
	next_button.pressed.disconnect(_on_next_phase)
	next_button.pressed.connect(_on_continue)

func stop_microphone():
	audio_player.stop()
	var mic_bus_index = AudioServer.get_bus_index("Microphone")
	AudioServer.set_bus_mute(mic_bus_index, false)

func _on_continue():
	pass
