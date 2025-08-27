@tool
extends Node
class_name NeuroArkStringTools

## String tools
static func get_substring_from(text: String, whatToFind: String, offset: int = 0, inverse:bool = false)->String:
	var index = text.find(whatToFind, 0)
	if index == -1:
		return "e1"
	var dataOffset: int = index + offset
	if  dataOffset >= text.length() || dataOffset < 0:
		return "e2"
	if inverse:
		return text.substr(0, dataOffset)
	return text.substr(dataOffset)

static func extract_path_name(path: NodePath)->String:
	var type: String = get_substring_from(str(path), ":")
	return path.get_name(path.get_name_count()-1)+type

static func create_number_label(number)-> String:
	if number is int:
		return str(number)+"."+"000"
	if number is float:
		var numberString: String = str(number)
		if numberString.contains("."):
			var indexPoint: int = numberString.find(".")
			var integers: String =  numberString.substr(0, indexPoint)
			var decimals: String =  numberString.substr(indexPoint+1, 3)
			return integers+"."+decimals
		else:
			return numberString+"."+"000"
	else :
		return "e3"
