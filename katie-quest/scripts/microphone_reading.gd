extends Node

var audio_input: AudioStreamPlayer
var audio_effect_capture: AudioEffectCapture
var volume_threshold = 0.001
var is_voice_active = false

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

  if volume > volume_threshold:
    if not is_voice_active:
      is_voice_active = true
      on_voice_started(volume)
  else:
    if is_voice_active:
      is_voice_active = false
      on_voice_stopped()

func on_voice_started(_volume: float):
  pass

func on_voice_stopped():
  pass

func stop_microphone():
  if audio_input:
    audio_input.stop()
