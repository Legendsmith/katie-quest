extends Resource
class_name SaveData

@export var current_scene: String = ""
@export var inventory: Inventory

const SAVE_PATH = "user://savegame.tres"

func save_to_file():
	var error = ResourceSaver.save(self, SAVE_PATH)

	if error == OK:
		print("Game saved successfully")
		return true

	else:
		print("Save failed with error: ", error)
		return false

static func load_from_file() -> SaveData:
	if ResourceLoader.exists(SAVE_PATH):
		var save_data = ResourceLoader.load(SAVE_PATH) as SaveData

		if save_data:
			print("Game loaded successfully")
			return save_data

		else:
			print("Save file exists but failed to load")

	else:
		print("No save file found")

	return SaveData.new()
