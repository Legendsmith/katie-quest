extends Node

var audio_input: AudioStreamPlayer
var audio_effect_capture: AudioEffectCapture
var required_duration = 2.0
var required_volume = 0.00001

var is_voice_active = false
var voice_start_time = 0.0
var is_requirement_met = false
var has_completed = false
var is_listening = true

var volume_history = []
var history_size = 10

func _ready():
	setup_microphone()

func setup_microphone():
	audio_effect_capture = AudioEffectCapture.new()
	AudioServer.add_bus_effect(0, audio_effect_capture)

	audio_input = AudioStreamPlayer.new()
	add_child(audio_input)

	var mic_stream = AudioStreamMicrophone.new()
	audio_input.stream = mic_stream
	audio_input.volume_db = -80
	audio_input.play()

func _process(_delta: float) -> void:
	if not is_listening or has_completed:
		return

	if audio_effect_capture:
		var frames_available = audio_effect_capture.get_frames_available()

		if frames_available > 0:
			var audio_data = audio_effect_capture.get_buffer(frames_available)
			process_audio_data(audio_data)

func process_audio_data(data: PackedVector2Array):
	var volume = 0.0

	for frame in data:
		volume += frame.length()

	volume = volume / data.size()

	volume_history.append(volume)

	if volume_history.size() > history_size:
		volume_history.pop_front()
	
	var avg_volume = 0.0
	for v in volume_history:
		avg_volume += v
	avg_volume = avg_volume / volume_history.size()
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if avg_volume >= required_volume:
		if not is_voice_active:
			is_voice_active = true
			voice_start_time = current_time
			is_requirement_met = false
			on_voice_started()

		else:
			var talking_duration = current_time - voice_start_time
			var progress = min(talking_duration / required_duration * 100, 100)
			print("Progress: ", int(progress), "%")

			if talking_duration >= required_duration and not is_requirement_met and not has_completed:
				is_requirement_met = true
				has_completed = true
				on_requirement_met(talking_duration, avg_volume)

	else:
		if is_voice_active:
			is_voice_active = false
			is_requirement_met = false
			on_voice_stopped()

func on_voice_started():
	print("Progress: 0%")

func on_requirement_met(duration: float, volume: float):
	print("SUCCESS! 100% Complete!")
	stop_microphone()

func on_voice_stopped():
	if is_requirement_met:
		print("Finished talking (requirement was met)")

	else:
		print("Stopped talking (requirement not met)")

func stop_microphone():
	is_listening = false
	if audio_input:
		audio_input.stop()

	print("Microphone stopped")
