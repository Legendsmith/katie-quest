extends Node

var selected_microphone_device: String = ""
var microphone_gain: float = 1.0

func set_microphone_settings(device: String, gain: float):
  selected_microphone_device = device
  microphone_gain = gain

func get_microphone_device() -> String:
  return selected_microphone_device

func get_microphone_gain() -> float:
  return microphone_gain
