@tool
extends Node2D
class_name  NeuroArkFileTools

static func save_string_to_disk(string: String, filePath: String)->bool:
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	var result = file.store_string(string)
	file.close()
	return result

static func save_json_to_disk(json_string: String, filePath: String)->bool:
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	var result = file.store_string(json_string)
	file.close()
	return result

static func load_string_from_disk(filePath: String)->String:
	var test_json_conv = JSON.new()
	var json_as_text = FileAccess.get_file_as_string(filePath)
	if json_as_text:
		return json_as_text
	return ""

static func load_json_from_disk(filePath: String)->JSON:
	var json_as_text = FileAccess.get_file_as_string(filePath)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
	return JSON.new()
