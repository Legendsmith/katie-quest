extends Node

const SETTINGS_FILE = "user://settings.save"

var selected_microphone_device: String = ""
var microphone_gain: float = 1.0
var talking_threshold: float = 0.0
var scream_threshold: float = 0.0

var master_volume: float = 100.0
var music_volume: float = 100.0
var effects_volume: float = 100.0
var voices_volume: float = 100.0

func _ready():
	load_settings()

func save_settings():
	var save_file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if save_file:
		var settings_data = {
			"microphone_device": selected_microphone_device,
			"microphone_gain": microphone_gain,
			"master_volume": master_volume,
			"music_volume": music_volume,
			"effects_volume": effects_volume,
			"voices_volume": voices_volume
		}
		save_file.store_string(JSON.stringify(settings_data))
		save_file.close()

func load_settings():
	if FileAccess.file_exists(SETTINGS_FILE):
		var save_file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				selected_microphone_device = data.get("microphone_device", "")
				microphone_gain = data.get("microphone_gain", 1.0)
				master_volume = data.get("master_volume", 100.0)
				music_volume = data.get("music_volume", 100.0)
				effects_volume = data.get("effects_volume", 100.0)
				voices_volume = data.get("voices_volume", 100.0)

func set_microphone_settings(device: String, gain: float):
	selected_microphone_device = device
	microphone_gain = gain
	save_settings()

func set_voice_thresholds(talking: float, screaming: float):
	talking_threshold = talking
	scream_threshold = screaming

func set_audio_volume(bus_name: String, volume: float):
	match bus_name:
		"Sound Master":
			master_volume = volume
		"Music":
			music_volume = volume
		"Effects":
			effects_volume = volume
		"Voices":
			voices_volume = volume
	save_settings()

func get_master_volume() -> float:
	return master_volume

func get_music_volume() -> float:
	return music_volume

func get_effects_volume() -> float:
	return effects_volume

func get_voices_volume() -> float:
	return voices_volume

func get_microphone_device() -> String:
	return selected_microphone_device

func get_microphone_gain() -> float:
	return microphone_gain

func get_talking_threshold() -> float:
	return talking_threshold

func get_scream_threshold() -> float:
	return scream_threshold
