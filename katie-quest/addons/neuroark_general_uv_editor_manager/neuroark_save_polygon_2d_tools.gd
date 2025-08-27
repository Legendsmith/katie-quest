@tool
extends Node2D
class_name NeuroArkSavePolygon2dTools

static func save_polygon_data_on_disk(polygon2d: Polygon2D, path:String)->bool:
	var polygonData: PackedVector2Array = polygon2d.polygon
	var polygonJson: String = NeuroArkArrayTools.packed_vector2_array_to_json_direct(polygonData)
	var uvData: PackedVector2Array = polygon2d.uv
	var uvJson: String = NeuroArkArrayTools.packed_vector2_array_to_json_direct(uvData)
	var polygonPointers:Array = polygon2d.polygons
	var pointersJson: String = NeuroArkArrayTools.array_of_packed_int_32_arrays_to_json_direct(polygonPointers)


	var weights: Array = NeuroArkPolygon2dTools.get_all_weights_from_polygon2d(polygon2d)
	var weightsJson: String = NeuroArkArrayTools.array_of_packed_float_32_arrays_to_json_direct(weights)
	var bonesPath: Array = NeuroArkPolygon2dTools.get_all_bone_paths_from_polygon2d(polygon2d)
	var bonesPathJson: String = NeuroArkArrayTools.array_of_node_paths_to_json_direct(bonesPath)

	var vertexCount: int = polygon2d.internal_vertex_count
	var json = "{ " + "\"polygonData\":" + polygonJson +  ", \"uvData\":" + uvJson + ", \"polygonPointers\":" + pointersJson + ", \"weights\":" + weightsJson + ", \"bonesPath\":" + bonesPathJson + ", \"vertexCount\":" + str(vertexCount) + " }"	
	return NeuroArkFileTools.save_json_to_disk(json, path)

static func load_polygon_data_from_disk(fileResPath: String)-> Polygon2D:
	var polygon2d = Polygon2D.new()
	var jsonString = FileAccess.get_file_as_string(fileResPath)
	if jsonString == "":
		return polygon2d	
	var dictionary = JSON.parse_string(jsonString)
	polygon2d.uv = NeuroArkArrayTools.dictionary_to_packed_vector2_array(dictionary.uvData)
	polygon2d.polygon = NeuroArkArrayTools.dictionary_to_packed_vector2_array(dictionary.polygonData) 
	polygon2d.polygons = NeuroArkArrayTools.dictionary_to_array_of_packed_int_32_arrays(dictionary.polygonPointers)
	polygon2d.internal_vertex_count = dictionary.vertexCount
	polygon2d = NeuroArkPolygon2dTools.set_bones_to_polygon2d(dictionary.bonesPath, dictionary.weights, polygon2d, true)
	return polygon2d

static func polygon_2d_has_data(polygon2d: Polygon2D)-> bool:
	if polygon2d.uv.size() > 0:
		return true
	if polygon2d.polygon.size() > 0:
		return true
	if polygon2d.polygons.size() > 0:
		return true
	return false
