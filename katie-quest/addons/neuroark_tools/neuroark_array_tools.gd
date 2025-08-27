@tool
extends Node
class_name NeuroArkArrayTools

static func remove_all_items_from_array(array: Array):
	var count: int = array.size()
	for i in array.size():
		count = count -1
		array.remove_at(count)

static func remove_items_by_index(array: Array, startIndex:int = -1, endIndex:int = -1, printDebug:bool = false):	
	var size: int = array.size()
	if size==0:
		if printDebug:
			NeuroArkNodeTools.print_debug_message("remove_items_by_index", "Array was empty.")
		return
	if startIndex == -1 && endIndex == -1:
		if printDebug:
			NeuroArkNodeTools.print_debug_message("remove_items_by_index", "The indexes are not valid")
		return
	if startIndex > endIndex || startIndex >= size && endIndex >= size || startIndex < 0 && endIndex < 0:
		if printDebug:
			NeuroArkNodeTools.print_debug_message("remove_items_by_index", "The start index was " + str(startIndex) + " while the end index was " + str(endIndex)+ " and array size was " + str(size))
		return
	
	while startIndex > 0:
		array.pop_front()
		startIndex -= 1
	var substractIndex: int = array.size() - (endIndex + 1)
	while substractIndex > 0:
		array.pop_back()
		substractIndex -= 1

static func add_item_to_array(array:Array, object)->Array:
	if not array.has(object):
		array.append(object)
	return array

static func remove_item_from_array(array:Array, object)->Array:
	if array.has(object):
		array.erase(object)
	return array

static func packed_vector2_array_to_json(data: PackedVector2Array)->String:
	var json_array = []
	for vector: Vector2 in data:
		json_array.append(JSON.stringify(vector))
	return JSON.stringify(json_array)

static func packed_vector2_array_to_json_direct(data: PackedVector2Array)->String:
	return JSON.stringify(JSON.from_native(data, true))

static func json_to_packed_vector2_array(json: String)->PackedVector2Array:
	var parsed:Array = JSON.parse_string(json)
	var result = PackedVector2Array()
	if parsed is Array:
		for item in parsed:
			if typeof(item) == TYPE_STRING:
				var vector:Vector2 = str_to_var(item)
				if typeof(vector) == TYPE_VECTOR2:
					result.append(vector)
	return result

static func packed_int_32_array_to_json(packed: PackedInt32Array) -> String:
	var array = []
	for i in packed.size():
		array.append(packed[i])
	return JSON.stringify(array)

static func packed_int_32_array_to_json_direct(packed: PackedInt32Array) -> String:
	return JSON.stringify(JSON.from_native(packed, true))

static func array_of_packed_int_32_arrays_to_json_direct(arrays: Array) -> String:
	return JSON.stringify(JSON.from_native(arrays, true))

static func array_of_packed_float_32_arrays_to_json_direct(arrays: Array) -> String:
	return JSON.stringify(JSON.from_native(arrays, true))

static func array_of_node_paths_to_json_direct(arrays: Array) -> String:
	return JSON.stringify(JSON.from_native(arrays, true))

static func dictionary_to_packed_vector2_array(input_dictionary: Dictionary):
	var packed_array = PackedVector2Array()
	var key = input_dictionary.keys()[0]
	var value = input_dictionary[key]
	for i in range(1, value.size(), 2):
		var vector: Vector2 = Vector2(value[i-1],value[i]) 
		packed_array.append(vector)
	return packed_array

static func dictionary_to_packed_int_32_array(input_dictionary: Dictionary):
	var packed_array = PackedInt32Array()
	var key = input_dictionary.keys()[0]
	var array = input_dictionary[key]
	for i in range(0, array.size(), 1):
		var value = array[i]
		var type = typeof(value)
		if type == TYPE_INT || type == TYPE_FLOAT:
			packed_array.append(value)
	return packed_array

static func dictionary_to_array_of_packed_int_32_arrays(array_dictionary: Array)->Array:
	var result: Array = Array()
	for i in range(0, array_dictionary.size(), 1):
		var dictionary: Dictionary = array_dictionary[i]
		var key = dictionary.keys()[0]
		var array = dictionary[key]
		var packed_array = PackedInt32Array()
		for j in range(0, array.size(), 1):
			var value = array[j]
			var type = typeof(value)
			if type == TYPE_INT || type == TYPE_FLOAT:
				packed_array.append(value)
		result.append(packed_array)
	return result

static func array_with_jsons_to_packed_vector2_array(jsons: Array)->PackedVector2Array:
	var result = PackedVector2Array()
	for json in jsons:
		var vector = JSON.parse_string(json)
		vector = str_to_var(json)
		if typeof(vector) == TYPE_VECTOR2:
			result.append(vector)
	return result

static func json_to_packed_int_32_array(json: String) -> PackedInt32Array:
	var parsed = JSON.parse_string(json)
	var result = PackedInt32Array()
	if parsed is Array:
		for item in parsed:
			if item is float:
				result.append(int(item))
			elif item is int:
				result.append(item)
	return result
